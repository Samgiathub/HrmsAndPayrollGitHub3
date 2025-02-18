using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040SalesWeekMaster
{
    public decimal WeekTranId { get; set; }

    public decimal? CmpId { get; set; }

    public int WMonth { get; set; }

    public int WYear { get; set; }

    public string? WeekOrder { get; set; }

    public DateTime? WeekStDate { get; set; }

    public DateTime? WeekEndDate { get; set; }

    public int? TotalDaysInWeek { get; set; }

    public int SortingNo { get; set; }

    public virtual ICollection<T0050SalesAssignedDetail> T0050SalesAssignedDetails { get; set; } = new List<T0050SalesAssignedDetail>();
}
