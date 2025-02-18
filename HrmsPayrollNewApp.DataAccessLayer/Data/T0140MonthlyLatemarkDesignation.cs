using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0140MonthlyLatemarkDesignation
{
    public decimal TranId { get; set; }

    public decimal? SalTranId { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? EmpId { get; set; }

    public string? LateMin { get; set; }

    public string? LateLunchMin { get; set; }

    public decimal? LateSec { get; set; }

    public decimal? LateLunchSec { get; set; }

    public DateTime? ForDate { get; set; }

    public decimal? NormalRate { get; set; }

    public decimal? LunchRate { get; set; }

    public decimal? LateAmount { get; set; }

    public decimal? LunchAmount { get; set; }

    public string? LateLimit { get; set; }

    public decimal? ShiftId { get; set; }

    public string? ShiftName { get; set; }

    public DateTime? InTime { get; set; }

    public DateTime? BreakOut { get; set; }

    public DateTime? BreakIn { get; set; }
}
