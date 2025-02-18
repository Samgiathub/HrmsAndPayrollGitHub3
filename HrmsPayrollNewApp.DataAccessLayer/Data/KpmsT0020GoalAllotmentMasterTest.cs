using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class KpmsT0020GoalAllotmentMasterTest
{
    public int GoalAllotId { get; set; }

    public int? CmpId { get; set; }

    public int? GoalSettingId { get; set; }

    public string? GoalSheetName { get; set; }

    public DateTime? GaltEffectDate { get; set; }

    public int? DeptId { get; set; }

    public int? DesigId { get; set; }

    public int? EmpId { get; set; }

    public int? UserId { get; set; }

    public DateTime? CreatedDate { get; set; }

    public DateTime? ModifyDate { get; set; }

    public int? IsActive { get; set; }

    public int? IsLock { get; set; }
}
