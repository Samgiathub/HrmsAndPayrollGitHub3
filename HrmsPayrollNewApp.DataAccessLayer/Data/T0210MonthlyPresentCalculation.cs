using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0210MonthlyPresentCalculation
{
    public decimal MPTranId { get; set; }

    public decimal EmpId { get; set; }

    public decimal CmpId { get; set; }

    public decimal? SalTranId { get; set; }

    public decimal? TempSalTranId { get; set; }

    public decimal ShiftId { get; set; }

    public decimal ShiftType { get; set; }

    public DateTime ForDate { get; set; }

    public decimal WorkingSec { get; set; }

    public decimal OtSec { get; set; }

    public decimal HolidayWorkSec { get; set; }

    public decimal WeekoffWorkSec { get; set; }

    public decimal MinShiftSec { get; set; }

    public decimal PDays { get; set; }

    public decimal HExOtSec { get; set; }

    public decimal ShiftSec { get; set; }

    public decimal BreakSec { get; set; }

    public decimal TotalWorkingSec { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster Emp { get; set; } = null!;

    public virtual T0200MonthlySalary? SalTran { get; set; }

    public virtual T0040ShiftMaster Shift { get; set; } = null!;
}
