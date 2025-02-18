using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class KpmsT0020GoalMaster
{
    public int CmpId { get; set; }

    public int GoalId { get; set; }

    public string GoalName { get; set; } = null!;

    public int IsActive { get; set; }

    public int SectionId { get; set; }

    public int UserId { get; set; }

    public DateTime CreatedDate { get; set; }

    public DateTime? ModifyDate { get; set; }
}
