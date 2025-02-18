using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0052EmpSelfAppraisal
{
    public decimal SelfAppId { get; set; }

    public decimal CmpId { get; set; }

    public decimal? SappraisalId { get; set; }

    public decimal? InitiateId { get; set; }

    public decimal? EmpId { get; set; }

    public string? Answer { get; set; }

    public decimal? Weightage { get; set; }

    public decimal? EmpScore { get; set; }

    public string? Comments { get; set; }

    public decimal? ManagerScore { get; set; }

    public string? ManagerComments { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0050HrmsInitiateAppraisal? Initiate { get; set; }

    public virtual T0040SelfAppraisalMaster? Sappraisal { get; set; }
}
