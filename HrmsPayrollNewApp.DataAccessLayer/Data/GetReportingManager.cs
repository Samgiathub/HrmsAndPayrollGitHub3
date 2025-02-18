using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class GetReportingManager
{
    public decimal EmpId { get; set; }

    public string EmployeeName { get; set; } = null!;

    public decimal CmpId { get; set; }
}
