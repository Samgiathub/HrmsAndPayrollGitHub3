using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T9999MacDetail
{
    public int TranId { get; set; }

    public int MacMasterId { get; set; }

    public int CmpId { get; set; }

    public string MacAddress { get; set; } = null!;

    public int EmpId { get; set; }

    public byte IsActive { get; set; }

    public DateTime? CreatedDate { get; set; }

    public DateTime? LastModified { get; set; }

    /// <summary>
    /// Login id of user modified data
    /// </summary>
    public int? ModifiedBy { get; set; }

    public string? PcName { get; set; }
}
