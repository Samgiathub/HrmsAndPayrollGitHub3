using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040InductionChecklist
{
    public decimal ChecklistId { get; set; }

    public string? ChecklistName { get; set; }

    public decimal? SortId { get; set; }

    public decimal? CmpId { get; set; }

    public DateTime? ModifyDate { get; set; }

    public decimal? ModifyBy { get; set; }

    public string? IpAddress { get; set; }
}
