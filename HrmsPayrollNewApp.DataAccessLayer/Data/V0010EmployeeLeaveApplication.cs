using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0010EmployeeLeaveApplication
{
    public string EmployeeName { get; set; } = null!;

    public decimal LeaveApplicationId { get; set; }

    public decimal RowId { get; set; }

    public DateTime FromDate { get; set; }

    public DateTime ToDate { get; set; }

    public decimal LeavePeriod { get; set; }

    public string ApplicationStatus { get; set; } = null!;
}
