using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0100HolidayApplication
{
    public string HdayName { get; set; } = null!;

    public decimal EmpId { get; set; }

    public decimal CmpId { get; set; }

    public string? HFromDate { get; set; }

    public string? HToDate { get; set; }

    public decimal HdayId { get; set; }

    public string? OpHolidayDate { get; set; }

    public decimal OpHolidayAppId { get; set; }

    public string OpHolidayStatus { get; set; } = null!;

    public string? EmpFullName { get; set; }

    public string? EmpFullNameDetail { get; set; }
}
