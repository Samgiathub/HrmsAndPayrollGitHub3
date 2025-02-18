using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0100HrmsCandidateSchemeLevel
{
    public decimal CandidateSchemeId { get; set; }

    public decimal CmpId { get; set; }

    public decimal ResumeId { get; set; }

    public decimal SchemeId { get; set; }

    public string Type { get; set; } = null!;

    public decimal TranId { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0040SchemeMaster Scheme { get; set; } = null!;

    public virtual T0052ResumeFinalApproval Tran { get; set; } = null!;
}
