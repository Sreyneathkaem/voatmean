const { createHomeroomClass, addStudentToHomeroomClass, getHomeroomClasses } = require('./homeroomClass.controller');
const db = require('../config/db');

// Mock dependencies
jest.mock('../config/db', () => ({
  query: jest.fn()
}));
jest.mock('../config/mongo', () => ({
  AuditLog: {
    create: jest.fn().mockResolvedValue({})
  }
}));

describe('Homeroom Class Controller', () => {
  let req, res, next;

  beforeEach(() => {
    req = { params: {}, body: {}, user: { user_id: 'admin-1', role: 'admin' } };
    res = {
      json: jest.fn().mockReturnThis(),
      status: jest.fn().mockReturnThis()
    };
    next = jest.fn();
  });

  describe('getHomeroomClasses', () => {
    it('should return a list of classes', async () => {
      const mockClasses = [{ class_id: 'c1', class_name: 'Grade 10A' }];
      db.query.mockResolvedValue({ rows: mockClasses });

      await getHomeroomClasses(req, res, next);

      expect(res.json).toHaveBeenCalledWith(mockClasses);
    });
  });

  describe('createHomeroomClass', () => {
    it('should create a class successfully', async () => {
      req.body = { class_name: '10A', academic_year_id: '2025-2026' };
      // Mock school lookup and insert
      db.query
        .mockResolvedValueOnce({ rows: [{ school_id: 's1' }] }) // school lookup
        .mockResolvedValueOnce({ rows: [{ class_id: 'c1', class_name: '10A' }] }); // insert

      await createHomeroomClass(req, res, next);

      expect(res.status).toHaveBeenCalledWith(201);
      expect(res.json).toHaveBeenCalledWith(expect.objectContaining({ class_name: '10A' }));
    });

    it('should return 400 if class_name is missing', async () => {
      req.body = { academic_year_id: '2025-2026' };
      await createHomeroomClass(req, res, next);
      expect(res.status).toHaveBeenCalledWith(400);
    });
  });

  describe('addStudentToHomeroomClass', () => {
    it('should enroll multiple students', async () => {
      req.params.classId = 'class-1';
      req.body = { student_ids: ['s1', 's2'] };

      // Mock successful inserts
      db.query.mockResolvedValue({ rows: [{ class_id: 'class-1' }] });

      await addStudentToHomeroomClass(req, res, next);

      expect(res.status).toHaveBeenCalledWith(201);
      expect(res.json).toHaveBeenCalledWith(expect.objectContaining({ newly_enrolled_count: 2 }));
    });

    it('should handle single student_id', async () => {
        req.params.classId = 'class-1';
        req.body = { student_id: 's1' };
        db.query.mockResolvedValue({ rows: [{ class_id: 'class-1' }] });

        await addStudentToHomeroomClass(req, res, next);

        expect(res.status).toHaveBeenCalledWith(201);
        expect(res.json).toHaveBeenCalledWith(expect.objectContaining({ newly_enrolled_count: 1 }));
      });
  });
});
