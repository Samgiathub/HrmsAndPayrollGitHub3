using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0040LeaveMaster
{
    public decimal EmpId { get; set; }

    public string? EmployeeName { get; set; }

    public string ApplicationCode { get; set; } = null!;

    public DateTime ApplicationDate { get; set; }

    public decimal LeaveApplicationId { get; set; }

    public string ApplicationStatus { get; set; } = null!;

    public decimal CmpId { get; set; }

    public decimal? SEmpId { get; set; }
}
