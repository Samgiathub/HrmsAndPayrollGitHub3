using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0110LeaveApplicationDetailReport
{
    public DateTime ApplicationDate { get; set; }

    public DateTime FromDate { get; set; }

    public DateTime ToDate { get; set; }

    public decimal LeavePeriod { get; set; }

    public string ApplicationStatus { get; set; } = null!;

    public string? LeaveReason { get; set; }

    public string? EmpFullName { get; set; }

    public string? ApprovedBy { get; set; }

    public decimal EmpId { get; set; }

    public string DeptName { get; set; } = null!;

    public string GrdName { get; set; } = null!;

    public string DesigName { get; set; } = null!;

    public string? TypeName { get; set; }

    public decimal LeaveApplicationId { get; set; }
}
