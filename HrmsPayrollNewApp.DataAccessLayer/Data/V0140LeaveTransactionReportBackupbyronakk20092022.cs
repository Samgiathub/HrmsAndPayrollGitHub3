using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0140LeaveTransactionReportBackupbyronakk20092022
{
    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public string? EmpCode { get; set; }

    public string? EmpFullName { get; set; }

    public string GrdName { get; set; } = null!;

    public string? DeptName { get; set; }

    public string? TypeName { get; set; }

    public string? CatName { get; set; }

    public string? DesigName { get; set; }

    public decimal LeaveId { get; set; }

    public string LeaveName { get; set; } = null!;

    public DateTime ForDate { get; set; }

    public decimal LeaveOpening { get; set; }

    public decimal LeaveCredit { get; set; }

    public decimal LeaveUsed { get; set; }

    public decimal LeaveClosing { get; set; }

    public decimal? LeavePosting { get; set; }

    public decimal? LeaveAdjLMark { get; set; }

    public decimal CompOffCredit { get; set; }

    public decimal CompOffDebit { get; set; }

    public decimal CompOffBalance { get; set; }

    public decimal CompOffUsed { get; set; }

    public decimal? BackDatedLeave { get; set; }

    public decimal HalfPaymentDays { get; set; }
}
