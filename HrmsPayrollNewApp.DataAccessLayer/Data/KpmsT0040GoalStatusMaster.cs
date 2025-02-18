using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class KpmsT0040GoalStatusMaster
{
    public int StatusId { get; set; }

    public int? CmpId { get; set; }

    public string StatusName { get; set; } = null!;

    public int? GalAltId { get; set; }
}
