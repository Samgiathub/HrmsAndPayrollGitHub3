using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0040TaskMaster
{
    public decimal TaskId { get; set; }

    public decimal? ProjectId { get; set; }

    public string? TaskName { get; set; }

    public string? TaskCode { get; set; }

    public string? TaskDescription { get; set; }

    public decimal? TaskTypeId { get; set; }

    public string? TaskPriority { get; set; }

    public decimal? ProjectStatusId { get; set; }

    public string? ProjectName { get; set; }

    public string? TaskTypeName { get; set; }

    public decimal? CmpId { get; set; }

    public int? IsReOpen { get; set; }

    public string StatusColor { get; set; } = null!;

    public int IsActive { get; set; }
}
