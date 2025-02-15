import os
import testinfra.utils.ansible_runner

testinfra_hosts = testinfra.utils.ansible_runner.AnsibleRunner(
    os.environ['MOLECULE_INVENTORY_FILE']).get_hosts('all')


def test_secure_config_file_exists(host):
    """
    Verify that the secure configuration file was created.
    """
    f = host.file("/etc/secure-arch.conf")
    assert f.exists, "Secure config file should exist"
    assert f.is_file, "Secure config file should be a file"


def test_secure_service_running_and_enabled(host):
    """
    Check that the secure-arch service is running and enabled.
    """
    s = host.service("secure-arch")
    assert s.is_running, "Secure service must be running"
    assert s.is_enabled, "Secure service must be enabled"
