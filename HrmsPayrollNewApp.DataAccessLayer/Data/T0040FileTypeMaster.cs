using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040FileTypeMaster
{
    public int FTypeId { get; set; }

    public string? TypeCode { get; set; }

    public string TypeTitle { get; set; } = null!;

    public DateTime? TypeCdtm { get; set; }

    public DateTime? TypeUdtm { get; set; }

    public string? TypeLog { get; set; }

    public int? IsActive { get; set; }

    public int? CmpId { get; set; }

    public string? FileTypeNumber { get; set; }

    public string? CreatedBy { get; set; }

    public DateTime? FileTypeStartDate { get; set; }

    public DateTime? FileTypeEndDate { get; set; }
}
