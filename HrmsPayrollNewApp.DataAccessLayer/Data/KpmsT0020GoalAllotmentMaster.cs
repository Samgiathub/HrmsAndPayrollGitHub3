using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class KpmsT0020GoalAllotmentMaster
{
    public int CmpId { get; set; }

    public int GoalAltId { get; set; }

    public string GoalSheetName { get; set; } = null!;

    public DateTime GaltEffectDate { get; set; }

    public string GaltDeptName { get; set; } = null!;

    public string GaltDesigName { get; set; } = null!;

    public string GaltEmpName { get; set; } = null!;

    public string GaltStatusName { get; set; } = null!;

    public int UserId { get; set; }

    public DateTime CreatedDate { get; set; }

    public DateTime? ModifyDate { get; set; }
}
