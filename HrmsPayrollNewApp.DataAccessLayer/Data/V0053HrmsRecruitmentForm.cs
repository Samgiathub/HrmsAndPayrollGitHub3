using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0053HrmsRecruitmentForm
{
    public decimal RecFormId { get; set; }

    public decimal CmpId { get; set; }

    public decimal RecPostId { get; set; }

    public decimal? FormId { get; set; }

    public string? FormName { get; set; }

    public int? Status { get; set; }

    public string? RecPostCode { get; set; }

    public string? JobTitle { get; set; }
}
