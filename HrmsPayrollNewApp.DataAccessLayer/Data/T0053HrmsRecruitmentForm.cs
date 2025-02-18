using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0053HrmsRecruitmentForm
{
    public decimal RecFormId { get; set; }

    public decimal CmpId { get; set; }

    public decimal RecPostId { get; set; }

    public decimal? FormId { get; set; }

    public string? FormName { get; set; }

    public int? Status { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0052HrmsPostedRecruitment RecPost { get; set; } = null!;
}
