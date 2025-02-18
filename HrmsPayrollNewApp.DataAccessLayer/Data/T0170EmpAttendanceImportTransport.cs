using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0170EmpAttendanceImportTransport
{
    public decimal TranId { get; set; }

    public decimal EmpId { get; set; }

    public decimal CmpId { get; set; }

    public decimal Month { get; set; }

    public decimal Year { get; set; }

    public string AttDetail { get; set; } = null!;

    public decimal PresentDays { get; set; }

    public decimal WeeklyOff { get; set; }

    public decimal Holiday { get; set; }

    public decimal Absent { get; set; }

    public DateOnly SystemDate { get; set; }

    public int LoginId { get; set; }
}
