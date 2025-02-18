using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class KpmsT0040LevelMaster
{
    public int CmpId { get; set; }

    public int LevelId { get; set; }

    public string LevelCode { get; set; } = null!;

    public string LevelName { get; set; } = null!;

    public int IsActive { get; set; }

    public int UserId { get; set; }

    public DateTime CreatedDate { get; set; }

    public DateTime? ModifyDate { get; set; }

    public int? LevelGrpId { get; set; }
}
