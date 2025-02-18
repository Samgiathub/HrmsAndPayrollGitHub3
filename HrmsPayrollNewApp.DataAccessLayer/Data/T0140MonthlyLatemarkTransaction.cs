using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0140MonthlyLatemarkTransaction
{
    public decimal TranId { get; set; }

    public decimal? SalTranId { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? EmpId { get; set; }

    public string? LateMin { get; set; }

    public decimal? LateSec { get; set; }

    public DateTime? ForDate { get; set; }

    public decimal? LateCalOnPercent { get; set; }

    public decimal? LateCalcOnAmt { get; set; }

    public decimal? LateAmount { get; set; }

    public string? LateLimit { get; set; }

    public decimal ShiftId { get; set; }

    public string? ShiftName { get; set; }

    public DateTime? InTime { get; set; }
}
