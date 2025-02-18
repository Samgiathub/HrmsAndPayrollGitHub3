using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0050TrainingInstituteMaster
{
    public decimal TrainingInstituteId { get; set; }

    public decimal CmpId { get; set; }

    public string TrainingInstituteName { get; set; } = null!;

    public string? TrainingInstituteCode { get; set; }

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

    public string? InstituteLocationCode { get; set; }
}
