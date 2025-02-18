using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class KpmsT0100GoalSetting
{
    public int GsId { get; set; }

    public string? GsSheetName { get; set; }

    public DateTime? GsFromDate { get; set; }

    public DateTime? GsToDate { get; set; }

    public int? GsWeightageTypeId { get; set; }

    public int? GsWeightageValue { get; set; }

    public int? GsStatusId { get; set; }

    public DateTime? GsCreatedDate { get; set; }

    public DateTime? GsUpdatedDate { get; set; }

    public int? CmpId { get; set; }

    public int? IsLock { get; set; }

    public bool? IsDraft { get; set; }
}
