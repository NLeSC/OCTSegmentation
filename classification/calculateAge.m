function age = calculateAge(Header)
% AGE = CALCULATEAGE(HEADER)
% Calculates the patient health from the Header file information (as stored
% in HE .vol files)

dob = Header.DOB; % double value, days whole number, starting 30.12.1899, 0.0
exam = Header.ExamTime; % Uint64, 100ns units, starting 1.1.1601

exam = exam / (10 * 1000 * 1000); % To seconds
exam = double(exam) / (60 * 60 * 24); % To days;
exam = exam - 109195; % To common start with DOB: 30.12.1899

age = exam - dob; % In days
age = age / 365.2425; % in years;

end