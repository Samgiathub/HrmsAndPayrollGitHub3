using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040QuarterDetail
{
    public int QtrId { get; set; }

    public int CmpId { get; set; }

    public DateTime EffectiveDate { get; set; }

    public string QtrName { get; set; } = null!;

    public int FromMonth { get; set; }

    public int ToMonth { get; set; }
}
