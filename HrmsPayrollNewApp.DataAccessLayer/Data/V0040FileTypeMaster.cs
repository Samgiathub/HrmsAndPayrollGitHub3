using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0040FileTypeMaster
{
    public int FTypeId { get; set; }

    public string TypeTitle { get; set; } = null!;

    public string TypeCode { get; set; } = null!;

    public int? CmpId { get; set; }

    public string FileTypeNumber { get; set; } = null!;

    public string CreatedBy { get; set; } = null!;

    public string? FileTypeStartDate { get; set; }

    public string? FileTypeEndDate { get; set; }

    public int IsActive { get; set; }
}
