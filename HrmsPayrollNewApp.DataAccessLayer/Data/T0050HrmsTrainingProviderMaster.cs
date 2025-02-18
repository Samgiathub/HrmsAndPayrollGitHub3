using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0050HrmsTrainingProviderMaster
{
    public decimal TrainingProId { get; set; }

    public string? ProviderName { get; set; }

    public string? ProviderContactName { get; set; }

    public decimal? ProviderNumber { get; set; }

    public string? ProviderDetail { get; set; }

    public string? ProviderEmail { get; set; }

    public string? ProviderWebsite { get; set; }

    public decimal? TrainingId { get; set; }

    public decimal? CmpId { get; set; }

    public string? ProviderEmpId { get; set; }

    public string? ProviderTypeId { get; set; }

    public string? ProviderFacultyId { get; set; }

    public decimal? ProviderInstituteId { get; set; }

    public decimal? TrainingInstituteLocId { get; set; }

    public virtual T0010CompanyMaster? Cmp { get; set; }

    public virtual T0050TrainingInstituteMaster? ProviderInstitute { get; set; }

    public virtual ICollection<T0120HrmsTrainingApproval> T0120HrmsTrainingApprovals { get; set; } = new List<T0120HrmsTrainingApproval>();

    public virtual T0040HrmsTrainingMaster? Training { get; set; }

    public virtual T0050TrainingLocationMaster? TrainingInstituteLoc { get; set; }
}
