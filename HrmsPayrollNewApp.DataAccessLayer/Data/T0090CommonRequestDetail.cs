using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0090CommonRequestDetail
{
    public decimal RequestId { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? EmpLoginId { get; set; }

    public string? RequestType { get; set; }

    public DateTime? RequestDate { get; set; }

    public string? RequestDetail { get; set; }

    public int Status { get; set; }

    public decimal? LoginId { get; set; }

    public string? FeedbackDetail { get; set; }

    public int? UserId { get; set; }

    public string? IpAddress { get; set; }

    public virtual T0010CompanyMaster? Cmp { get; set; }

    public virtual T0011Login? EmpLogin { get; set; }
}
