using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class KpmsT0040FrequencyMaster
{
    public int CmpId { get; set; }

    public int FrequencyId { get; set; }

    public string FrequencyCode { get; set; } = null!;

    public string Frequency { get; set; } = null!;

    public int IsActive { get; set; }

    public int UserId { get; set; }

    public DateTime CreatedDate { get; set; }

    public DateTime? ModifyDate { get; set; }
}
