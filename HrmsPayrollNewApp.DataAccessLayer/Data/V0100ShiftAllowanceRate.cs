using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0100ShiftAllowanceRate
{
    public DateTime? EffectiveDate { get; set; }

    public int CmpId { get; set; }

    public decimal AdId { get; set; }

    public string AdName { get; set; } = null!;

    public string AdSortName { get; set; } = null!;
}
