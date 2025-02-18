using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class TbEmployee
{
    public int EmployeeId { get; set; }

    public string? EmployeeName { get; set; }

    public int? ManagerId { get; set; }
}
