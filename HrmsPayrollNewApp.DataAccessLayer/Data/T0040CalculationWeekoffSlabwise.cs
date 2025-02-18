using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040CalculationWeekoffSlabwise
{
    public decimal? RowId { get; set; }

    public decimal? EmpId { get; set; }

    public DateTime? ForDate { get; set; }

    public decimal? Duration { get; set; }

    public decimal? ShiftId { get; set; }
}
