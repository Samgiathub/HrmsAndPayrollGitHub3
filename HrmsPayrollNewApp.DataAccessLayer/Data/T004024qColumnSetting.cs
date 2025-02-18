using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T004024qColumnSetting
{
    public int TranId { get; set; }

    public int It24qId { get; set; }

    public DateTime EffectiveDate { get; set; }

    public int SortId { get; set; }

    public string ColumnNo { get; set; } = null!;

    public string ColumnName { get; set; } = null!;

    public bool SkipColumn { get; set; }
}
