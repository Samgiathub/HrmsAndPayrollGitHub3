using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class TblConvertJsontoTableObject
{
    public int EmployeeId { get; set; }

    public string? EmpCode { get; set; }

    public string? DayInDate { get; set; }

    public string? DayInTime { get; set; }

    public string? DayOutDate { get; set; }

    public string? DayOutTime { get; set; }
}
