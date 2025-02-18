using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0050TrainingInstituteMaster
{
    public decimal TrainingInstituteId { get; set; }

    public decimal CmpId { get; set; }

    public string TrainingInstituteName { get; set; } = null!;

    public string? TrainingInstituteCode { get; set; }

    public string? InstituteLocationCode { get; set; }

    public string? InstituteAddress { get; set; }

    public string? InstituteCity { get; set; }

    public decimal? InstituteStateId { get; set; }

    public decimal? InstituteCountryId { get; set; }

    public string? InstitutePinCode { get; set; }

    public string? InstituteTelephone { get; set; }

    public string? InstituteFaxNo { get; set; }

    public string? InstituteEmail { get; set; }

    public string? InstituteWebsite { get; set; }

    public string? InstituteAffiliatedBy { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0020StateMaster? InstituteState { get; set; }

    public virtual ICollection<T0050HrmsTrainingProviderMaster> T0050HrmsTrainingProviderMasters { get; set; } = new List<T0050HrmsTrainingProviderMaster>();

    public virtual ICollection<T0050TrainingLocationMaster> T0050TrainingLocationMasters { get; set; } = new List<T0050TrainingLocationMaster>();

    public virtual ICollection<T0055TrainingFaculty> T0055TrainingFaculties { get; set; } = new List<T0055TrainingFaculty>();
}
