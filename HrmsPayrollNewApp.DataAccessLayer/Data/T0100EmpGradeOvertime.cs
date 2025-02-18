using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0100EmpGradeOvertime
{
    public decimal OtTranId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public DateTime ForDate { get; set; }

    public string OtHours { get; set; } = null!;

    public decimal GrdId { get; set; }

    public decimal? AmountCredit { get; set; }

    public decimal? AmountDebit { get; set; }

    public DateTime? ImportDate { get; set; }

    public decimal? BasicSalary { get; set; }

    public byte IsHoliday { get; set; }
}
