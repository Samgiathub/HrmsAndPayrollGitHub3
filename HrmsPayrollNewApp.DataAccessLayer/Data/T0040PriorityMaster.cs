using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040PriorityMaster
{
    public int PriorityId { get; set; }

    public string? PmCode { get; set; }

    public string? PmTitle { get; set; }

    public string? PmColor { get; set; }

    public int? PmStatus { get; set; }

    public DateTime? PmCreatedDate { get; set; }

    public DateTime? PmUpdatedDate { get; set; }
}
