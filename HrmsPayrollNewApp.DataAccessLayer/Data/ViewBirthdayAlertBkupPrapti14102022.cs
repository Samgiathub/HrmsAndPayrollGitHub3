using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class ViewBirthdayAlertBkupPrapti14102022
{
    public int? LikeCount { get; set; }

    public int? CommentCount { get; set; }

    public decimal EmpId { get; set; }

    public string? EmpName { get; set; }

    public string DeptName { get; set; } = null!;

    public decimal? DesigId { get; set; }

    public string DesigName { get; set; } = null!;

    public decimal BranchId { get; set; }

    public string? BranchName { get; set; }

    public string? BranchCode { get; set; }

    public DateTime? Date { get; set; }

    public string? ImageName { get; set; }

    public string Groupby { get; set; } = null!;

    public decimal CmpId { get; set; }

    public int NotificationFlag { get; set; }

    public byte LikeFlag { get; set; }
}
