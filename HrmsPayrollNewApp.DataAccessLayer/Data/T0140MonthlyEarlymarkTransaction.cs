using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0140MonthlyEarlymarkTransaction
{
    public decimal TranId { get; set; }

    public decimal? SalTranId { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? EmpId { get; set; }

    public string? EarlyMin { get; set; }

    public decimal? EarlySec { get; set; }

    public DateTime? ForDate { get; set; }

    public decimal? EarlyCalOnPercent { get; set; }

    public decimal? EarlyCalcOnAmt { get; set; }

    public decimal? EarlyAmount { get; set; }

    public string? EarlyLimit { get; set; }

    public decimal ShiftId { get; set; }

    public string? ShiftName { get; set; }

    public DateTime? OutTime { get; set; }
}
