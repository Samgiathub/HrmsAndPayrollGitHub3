using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040IncidentMaster
{
    public int IncidentId { get; set; }

    public decimal? CmpId { get; set; }

    public DateTime? CreationDate { get; set; }

    public DateTime? ApplicableDate { get; set; }

    public string? IncidentName { get; set; }

    public string? IncidentStatus { get; set; }

    public string? DetailInformation { get; set; }
}
