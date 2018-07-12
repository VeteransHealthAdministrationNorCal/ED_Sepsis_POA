use 
  LSV
select distinct 
  presentAdmit.PatientSID,
  patient.PatientSSN,
  patient.PatientName,
  patient.DeceasedFlag,
  patient.DeathDateTime,
  cast(inpat.AdmitDateTime as date) as AdmitDate,
  datediff(d, inpat.AdmitDateTime, patient.DeathDateTime) as t2Death,
  presentAdmit.PresentOnAdmissionCode
from
  Inpat.PresentOnAdmission as presentAdmit 
  inner join BISL_R1VX.AR3Y_Inpat_Inpatient as inpat 
    on inpat.InpatientSID = presentAdmit.InpatientSID
  inner join BISL_R1VX.AR3Y_SPatient_SPatient as patient 
    on presentAdmit.PatientSID = patient.PatientSID 
    and inpat.Sta3n = patient.Sta3n
  inner join Dim.ICD10 as icd10 
    on presentAdmit.ICD10SID = icd10.ICD10SID
  inner join Dim.ICD10DescriptionVersion as icd10Label 
    on icd10Label.ICD10SID = icd10.ICD10SID 
	and icd10.sta3n = icd10Label.Sta3n
where
  patient.Sta3n = '612'
  and patient.CDWPossibleTestPatientFlag <> 'y'
  and presentAdmit.PresentOnAdmissionCode = 'Y' 
  and inpat.AdmitDateTime >= Dateadd(d, -30, getdate()) 
  and (icd10.ICD10Code like ('[A][0-9][0-9]%') 
    OR icd10.ICD10Code like ('R78.81') 
    OR icd10.ICD10Code like ('B37.%')
    OR icd10.ICD10Code like ('R65.2[0-1]%'))
  and (datediff(d, inpat.AdmitDateTime, patient.DeathDateTime) <= 30 
    OR datediff(d, inpat.AdmitDateTime, patient.DeathDateTime) is NULL)
order by
  patient.PatientSSN
