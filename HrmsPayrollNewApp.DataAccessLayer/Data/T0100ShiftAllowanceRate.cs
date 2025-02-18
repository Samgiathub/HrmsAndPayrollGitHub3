using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0100ShiftAllowanceRate
{
    public int TranId { get; set; }

    public int CmpId { get; set; }

    public int ShiftId { get; set; }

    public decimal Rate { get; set; }

    public DateTime? EffectiveDate { get; set; }

    public byte IsEmpRate { get; set; }

    public DateTime CreatedDate { get; set; }

    public decimal MinimumCount { get; set; }

    public decimal AdId { get; set; }
}
