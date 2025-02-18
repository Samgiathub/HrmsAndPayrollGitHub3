using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0050HrmsTrainingProviderMaster
{
    public decimal TrainingProId { get; set; }

    public string? ProviderName { get; set; }

    public string EmpFullName { get; set; } = null!;

    public string? ProviderContactName { get; set; }

    public decimal? ProviderNumber { get; set; }

    public string? ProviderDetail { get; set; }

    public string? ProviderEmail { get; set; }

    public string? ProviderWebsite { get; set; }

    public decimal? TrainingId { get; set; }

    public decimal? CmpId { get; set; }

    public string? ProviderEmpId { get; set; }

    public string? ProviderTypeId { get; set; }

    public string? TrainingName { get; set; }

    public string ProviderType { get; set; } = null!;

    public string? ProviderFacultyId { get; set; }

    public decimal? ProviderInstituteId { get; set; }

    public string? TrainingInstituteName { get; set; }

    public string? TrainingInstituteCode { get; set; }

    public decimal? TrainingInstituteLocId { get; set; }

    public string? InstituteLocationCode { get; set; }

    public string FacultyName { get; set; } = null!;
}
