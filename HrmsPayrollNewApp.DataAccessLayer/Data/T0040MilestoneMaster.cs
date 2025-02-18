using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040MilestoneMaster
{
    public decimal MilestoneId { get; set; }

    public string? MilestoneName { get; set; }

    public string? MilestoneDescription { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? CreatedBy { get; set; }

    public DateTime? CreatedDate { get; set; }

    public decimal? ModifyBy { get; set; }

    public DateTime? ModifyDate { get; set; }

    public virtual ICollection<T0040TaskMaster> T0040TaskMasters { get; set; } = new List<T0040TaskMaster>();
}
