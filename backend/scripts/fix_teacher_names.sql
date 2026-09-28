-- Fix teacher names with proper UTF-8 encoding in PostgreSQL
SET client_encoding = 'UTF8';

UPDATE users SET full_name = 'លោកគ្រូ សុខ សំណាង' WHERE email = 'sok.samnang@voatmean.edu.kh';
UPDATE users SET full_name = 'អ្នកគ្រូ កែវ បុប្ផា' WHERE email = 'keo.bopha@voatmean.edu.kh';
UPDATE users SET full_name = 'លោកគ្រូ ហេង ពិសិដ្ឋ' WHERE email = 'heng.piseth@voatmean.edu.kh';
UPDATE users SET full_name = 'អ្នកគ្រូ ចាន់ ស្រីមុំ' WHERE email = 'chan.sreymom@voatmean.edu.kh';
UPDATE users SET full_name = 'លោកគ្រូ ជា វណ្ណៈ' WHERE email = 'chea.vannak@voatmean.edu.kh';
UPDATE users SET full_name = 'អ្នកគ្រូ កែម ស្រីនីត' WHERE email = 'k.sreyneath24@gmail.com';
UPDATE users SET full_name = 'លោកគ្រូ ចាន់ធី (Mr. Chanthy)' WHERE email = 'chanthyrith2@gmail.com';
UPDATE users SET full_name = 'លោកគ្រូ មករា (Mr. Makara)' WHERE email = 'sovannmakara2@gmail.com';
UPDATE users SET full_name = 'អ្នកគ្រូ ដារីកា (Ms. Darika)' WHERE email = 'darikasophea2@gmail.com';
UPDATE users SET full_name = 'អ្នកគ្រូ រង្សី (Ms. Rangsey)' WHERE email = 'virakrangsey@gmail.com';
UPDATE users SET full_name = 'អ្នកគ្រូ ស្រីនាង (Ms. Sreyneang)' WHERE email = 'neangsrey137@gmail.com';

SELECT user_id, full_name, email FROM users WHERE role = 'teacher';
