using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0160AttendanceApplication
{
    public decimal AttAppId { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? EmpId { get; set; }

    public DateTime? ForDate { get; set; }

    public decimal? ShiftSec { get; set; }

    public decimal? PDays { get; set; }

    public string? ModifyBy { get; set; }

    public DateTime? ModifyDate { get; set; }

    public string? IpAddress { get; set; }
}
