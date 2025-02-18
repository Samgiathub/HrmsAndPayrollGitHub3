using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0020StateMaster
{
    public decimal StateId { get; set; }

    public decimal CmpId { get; set; }

    public string StateName { get; set; } = null!;

    public decimal? LocId { get; set; }

    public string? PtDeductionType { get; set; }

    public string? PtDeductionMonth { get; set; }

    public string? PtEnrollCertNo { get; set; }

    public byte ApplicablePtMaleFemale { get; set; }

    public string? EsicStateCode { get; set; }

    public string? EsicRegAddr { get; set; }

    public virtual ICollection<T0030BranchMaster> T0030BranchMasters { get; set; } = new List<T0030BranchMaster>();

    public virtual ICollection<T0050TrainingInstituteMaster> T0050TrainingInstituteMasters { get; set; } = new List<T0050TrainingInstituteMaster>();
}
