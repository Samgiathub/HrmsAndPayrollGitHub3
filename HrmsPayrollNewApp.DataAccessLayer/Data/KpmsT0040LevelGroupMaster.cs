using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class KpmsT0040LevelGroupMaster
{
    public int LevelGroupId { get; set; }

    public string LevelGroupName { get; set; } = null!;

    public int? CmpId { get; set; }
}
