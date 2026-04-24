<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

class TestController extends Controller
{
    public function index() {
    return response()->json([
        'status' => 'success',
        'message' => 'Koneksi ke Laravel Berhasil!'
    ]);
}

public function getServices() {
    $services = \App\Models\Service::all();
    return response()->json($services);
}

}
