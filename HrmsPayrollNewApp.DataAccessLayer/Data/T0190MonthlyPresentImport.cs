using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0190MonthlyPresentImport
{
    public decimal TranId { get; set; }

    public decimal EmpId { get; set; }

    public decimal CmpId { get; set; }

    public int Month { get; set; }

    public int Year { get; set; }

    public DateTime ForDate { get; set; }

    public decimal PDays { get; set; }

    public decimal ExtraDays { get; set; }

    public decimal ExtraDayMonth { get; set; }

    public decimal ExtraDayYear { get; set; }

    public decimal CancelWeekoffDay { get; set; }

    public decimal CancelHoliday { get; set; }

    public decimal OverTime { get; set; }

    public decimal PaybleAmount { get; set; }

    public int? UserId { get; set; }

    public DateTime? TimeStamp { get; set; }

    public decimal BackdatedLeaveDays { get; set; }

    public decimal WoOtHour { get; set; }

    public decimal HoOtHour { get; set; }

    public decimal PresentOnHoliday { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster Emp { get; set; } = null!;
}
